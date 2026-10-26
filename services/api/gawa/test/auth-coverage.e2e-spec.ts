import { Test } from '@nestjs/testing';
import { INestApplication, RequestMethod } from '@nestjs/common';
import {
  DiscoveryModule,
  DiscoveryService,
  MetadataScanner,
} from '@nestjs/core';
import { METHOD_METADATA, PATH_METADATA } from '@nestjs/common/constants';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { IS_PUBLIC_KEY } from '../src/modules/auth/public.decorator';

interface Route {
  method: string;
  path: string;
  isPublic: boolean;
}

const joinPath = (...parts: string[]) =>
  '/' +
  parts
    .flatMap((p) => p.split('/'))
    .filter(Boolean)
    .join('/');

// Enumerates every controller route so a new endpoint cannot ship unguarded
// without this test noticing.
function discoverRoutes(app: INestApplication): Route[] {
  const scanner = new MetadataScanner();
  return app
    .get(DiscoveryService)
    .getControllers()
    .flatMap((wrapper) => {
      const controller = wrapper.metatype as any;
      const prefix: string =
        Reflect.getMetadata(PATH_METADATA, controller) ?? '';
      const classPublic =
        Reflect.getMetadata(IS_PUBLIC_KEY, controller) === true;
      const proto = controller.prototype;
      return scanner.getAllMethodNames(proto).flatMap((name) => {
        const handler = proto[name];
        const method: RequestMethod | undefined = Reflect.getMetadata(
          METHOD_METADATA,
          handler,
        );
        if (method === undefined) return [];
        return [
          {
            method: RequestMethod[method].toLowerCase(),
            path: joinPath(
              prefix,
              Reflect.getMetadata(PATH_METADATA, handler) ?? '',
            ),
            isPublic:
              classPublic ||
              Reflect.getMetadata(IS_PUBLIC_KEY, handler) === true,
          },
        ];
      });
    });
}

describe('Authentication coverage (e2e)', () => {
  let app: INestApplication<App>;
  let routes: Route[];

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule, DiscoveryModule],
    }).compile();
    app = moduleRef.createNestApplication();
    await app.init();
    routes = discoverRoutes(app);
  });

  afterAll(async () => {
    await app.close();
  });

  it('discovers the API surface', () => {
    const signatures = routes.map((r) => `${r.method.toUpperCase()} ${r.path}`);
    expect(signatures).toEqual(
      expect.arrayContaining([
        'GET /groups',
        'GET /groups/invites',
        'POST /groups/:id/invite/accept',
        'GET /subscriptions/:id',
        'GET /obligations',
        'GET /users/me',
      ]),
    );
  });

  it('only the health check is public', () => {
    expect(routes.filter((r) => r.isPublic).map((r) => r.path)).toEqual(['/']);
  });

  it('rejects every non-public route without a token', async () => {
    for (const route of routes.filter((r) => !r.isPublic)) {
      const url = route.path.replace(/:\w+/g, '1');
      const res = await (request(app.getHttpServer()) as any)[route.method](
        url,
      );
      expect({
        route: `${route.method.toUpperCase()} ${route.path}`,
        status: res.status,
      }).toEqual({
        route: `${route.method.toUpperCase()} ${route.path}`,
        status: 401,
      });
    }
  });

  it('rejects a malformed token', async () => {
    await request(app.getHttpServer())
      .get('/groups')
      .set('Authorization', 'Bearer not-a-real-token')
      .expect(401);
  });

  it.each([
    ['post', '/users'],
    ['get', '/users/1'],
    ['delete', '/users/1'],
    ['post', '/obligations'],
    ['patch', '/obligations/1'],
    ['post', '/payments'],
    ['get', '/transactions'],
    ['get', '/expenses'],
  ])('no longer exposes %s %s', (method, path) => {
    const exists = routes.some(
      (r) =>
        r.method === method &&
        new RegExp('^' + r.path.replace(/:\w+/g, '[^/]+') + '$').test(path),
    );
    expect(exists).toBe(false);
  });

  it('keeps the health check reachable', async () => {
    await request(app.getHttpServer()).get('/').expect(200);
  });
});
