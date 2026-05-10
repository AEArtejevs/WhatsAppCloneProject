import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

type AuthenticatedRequest = Request & {
  user: {
    userId: number;
    email: string;
  };
};

// Main route group for auth endpoints.
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) { }

  // POST /auth/register
  // Creates a new account and returns the new user with a token.
  @Post('register')
  register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  // POST /auth/login
  // Logs in an existing user and returns their user data with a token.
  @Post('login')
  login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  // This route needs a valid JWT token.
  @UseGuards(AuthGuard('jwt'))
  // GET /auth/me
  // Returns the profile for the currently logged-in user.
  @Get('me')
  me(@Req() request: AuthenticatedRequest) {
    // The JWT strategy adds the logged-in user to request.user.
    return this.authService.getMe(request.user.userId);
  }
}
