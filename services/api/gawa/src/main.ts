// Load .env before anything else so GOOGLE_APPLICATION_CREDENTIALS is set
// when firebase-admin initializes (it reads the env var at init time).
import 'dotenv/config';
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
