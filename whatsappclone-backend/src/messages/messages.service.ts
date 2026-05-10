import {
    BadRequestException,
    ForbiddenException,
    Injectable,
    NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class MessagesService {
    constructor(private readonly prisma: PrismaService) { }

    // Gets all messages for one chat, but only if this user belongs to that chat.
    async getChatMessages(userId: number, chatId: number) {
        await this.checkUserIsChatMember(userId, chatId);

        return this.prisma.chatMessage.findMany({
            where: {
                chatId,
            },
            orderBy: {
                // Oldest messages first, so the chat can be shown in normal reading order.
                createdAt: 'asc',
            },
            include: this.getMessageInclude(),
        });
    }

    // Creates a new text message from the logged-in user to the other chat member.
    async sendMessage(userId: number, chatId: number, content: string) {
        await this.checkUserIsChatMember(userId, chatId);

        // Remove spaces before checking the message, so "   " is not accepted.
        const trimmedContent = content?.trim();

        if (!trimmedContent) {
            throw new BadRequestException('Message content cannot be empty');
        }

        // Private chats have two users, so the receiver is the member who is not the sender.
        const receiverId = await this.getReceiverId(userId, chatId);

        return this.prisma.chatMessage.create({
            data: {
                chatId,
                senderId: userId,
                receiverId,
                content: trimmedContent,
            },
            include: this.getMessageInclude(),
        });
    }

    // Finds the other user in this private chat.
    private async getReceiverId(userId: number, chatId: number) {
        const chatMembers = await this.prisma.chatMember.findMany({
            where: {
                chatId,
            },
        });

        const receiver = chatMembers.find((member) => member.userId !== userId);

        if (!receiver) {
            throw new BadRequestException('Receiver not found in this chat');
        }

        return receiver.userId;
    }

    // Stops users from reading or sending messages in chats they are not part of.
    private async checkUserIsChatMember(userId: number, chatId: number) {
        const chat = await this.prisma.chat.findUnique({
            where: {
                id: chatId,
            },
        });

        if (!chat) {
            throw new NotFoundException('Chat not found');
        }

        const membership = await this.prisma.chatMember.findUnique({
            where: {
                chatId_userId: {
                    chatId,
                    userId,
                },
            },
        });

        if (!membership) {
            throw new ForbiddenException('You are not a member of this chat');
        }

        return membership;
    }

    // Adds basic sender and receiver details to every returned message.
    private getMessageInclude() {
        return {
            sender: {
                select: {
                    id: true,
                    username: true,
                    email: true,
                },
            },
            receiver: {
                select: {
                    id: true,
                    username: true,
                    email: true,
                },
            },
        };
    }
}
