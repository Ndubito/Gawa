import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true, 
    // Automatically remove non-whitelisted properties
    forbidNonWhitelisted: true, 
    // Throws an error if non-whitelisted properties are found
    transform: true 
    // Automatically transform payloads to DTOs
  })); 
  await app.listen(process.env.PORT ?? 8000);
}
bootstrap();
