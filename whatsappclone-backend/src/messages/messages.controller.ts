import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';
import { CreateMessageDto } from './dto/create-message.dto';
import { MessagesService } from './messages.service';

type AuthenticatedRequest = Request & {
    user: {
        userId: number;
        email: string;
    };
};

// Every route in this controller needs a valid JWT token.
@UseGuards(AuthGuard('jwt'))
// These routes work with messages inside one chat.
@Controller('chats/:chatId/messages')
export class MessagesController {
    constructor(private readonly messagesService: MessagesService) { }

    // GET /chats/:chatId/messages
    // Returns all messages for the selected chat.
    @Get()
    getChatMessages(
        @Req() request: AuthenticatedRequest,
        @Param('chatId') chatId: string,
    ) {
        // The JWT guard adds the logged-in user to request.user.
        return this.messagesService.getChatMessages(
            request.user.userId,
            // Route params arrive as strings, but the database id is a number.
            Number(chatId),
        );
    }

    // POST /chats/:chatId/messages
    // Sends a new message in the selected chat.
    @Post()
    sendMessage(
        @Req() request: AuthenticatedRequest,
        @Param('chatId') chatId: string,
        @Body() createMessageDto: CreateMessageDto,
    ) {
        return this.messagesService.sendMessage(
            request.user.userId,
            Number(chatId),
            createMessageDto.content,
        );
    }
}
