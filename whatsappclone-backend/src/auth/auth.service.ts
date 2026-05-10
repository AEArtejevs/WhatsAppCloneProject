import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) { }

  // Creates a new user account and returns a JWT token for immediate login.
  async register(registerDto: RegisterDto) {
    // Email must be unique, so check if another account already uses it.
    const existingUser = await this.prisma.user.findUnique({
      where: {
        email: registerDto.email,
      },
    });

    if (existingUser) {
      throw new ConflictException('Email is already registered');
    }

    // Store a hashed password, never the plain password from the request.
    const passwordHash = await bcrypt.hash(registerDto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        username: registerDto.username,
        email: registerDto.email,
        passwordHash: passwordHash,
      },
      select: {
        // Return safe user fields only, not the password hash.
        id: true,
        username: true,
        email: true,
        createdAt: true,
      },
    });

    // "sub" is the standard JWT field for the user id.
    const token = this.jwtService.sign({
      sub: user.id,
      email: user.email,
    });

    return {
      token,
      user,
    };
  }

  // Checks email and password, then returns a JWT token if they are correct.
  async login(loginDto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: {
        email: loginDto.email,
      },
    });

    if (!user) {
      // Use a general message so attackers cannot know which email exists.
      throw new UnauthorizedException('Invalid email or password');
    }

    // Compare the plain password from login with the saved password hash.
    const passwordMatches = await bcrypt.compare(
      loginDto.password,
      user.passwordHash,
    );

    if (!passwordMatches) {
      // Keep the same error as above for security.
      throw new UnauthorizedException('Invalid email or password');
    }

    // Create a token the frontend can send in the Authorization header.
    const token = this.jwtService.sign({
      sub: user.id,
      email: user.email,
    });

    return {
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
      },
    };
  }

  // Returns the logged-in user's profile from their JWT user id.
  async getMe(userId: number) {
    return this.prisma.user.findUnique({
      where: {
        id: userId,
      },
      select: {
        // Return public profile fields only.
        id: true,
        username: true,
        email: true,
        createdAt: true,
      },
    });
  }

}
