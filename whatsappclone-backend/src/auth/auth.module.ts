import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [
    // PrismaModule gives this module access to the database service.
    PrismaModule,
    // PassportModule lets NestJS use authentication strategies like JWT.
    PassportModule,
    // JwtModule signs and verifies JWT tokens.
    JwtModule.register({
      // Development secret for local use. In production this should come from an env variable.
      secret: 'dev_secret_change_later',
      signOptions: {
        // Tokens stay valid for 7 days.
        expiresIn: '7d',
      },
    }),
  ],
  // Controller defines the HTTP routes for auth.
  controllers: [AuthController],
  // AuthService handles register/login, JwtStrategy validates protected routes.
  providers: [AuthService, JwtStrategy],
  // Export these so other modules can use JWT or Passport if needed.
  exports: [JwtModule, PassportModule],
})
export class AuthModule {}
