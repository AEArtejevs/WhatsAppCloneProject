import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';
import { UsersService } from './users.service';

type AuthenticatedRequest = Request & {
    user: {
        userId: number;
        email: string;
    };
};

// Every user route requires the user to be logged in with a JWT token.
@UseGuards(AuthGuard('jwt'))
// Main route group for user endpoints.
@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    // GET /users
    // Returns users that the logged-in user can start chats with.
    @Get()
    getContacts(@Req() request: AuthenticatedRequest) {
        // The JWT guard adds the logged-in user to request.user.
        return this.usersService.getContacts(request.user.userId);
    }
}
