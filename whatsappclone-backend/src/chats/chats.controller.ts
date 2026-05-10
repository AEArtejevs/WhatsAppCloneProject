import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';
import { ChatsService } from './chats.service';
import { CreatePrivateChatDto } from './dto/create-private-chat.dto';

type AuthenticatedRequest = Request & {
    user: {
        userId: number;
        email: string;
    };
};

// Every chat route requires the user to be logged in with a JWT token.
@UseGuards(AuthGuard('jwt'))
// Main route group for chat endpoints.
@Controller('chats')
export class ChatsController {
    constructor(private readonly chatsService: ChatsService) { }

    // GET /chats
    // Returns all chats for the logged-in user.
    @Get()
    getUserChats(@Req() request: AuthenticatedRequest) {
        // The JWT guard adds the logged-in user to request.user.
        return this.chatsService.getUserChats(request.user.userId);
    }

    // POST /chats/private
    // Starts or returns a private chat with another user.
    @Post('private')
    createPrivateChat(
        @Req() request: AuthenticatedRequest,
        @Body() createPrivateChatDto: CreatePrivateChatDto,
    ) {
        return this.chatsService.createPrivateChat(
            // Current user comes from the JWT token.
            request.user.userId,
            // Other user comes from the request body.
            createPrivateChatDto.otherUserId,
        );
    }
}
