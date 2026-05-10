import {
    BadRequestException,
    Injectable,
    NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChatsService {
    constructor(private readonly prisma: PrismaService) { }

    // Gets all chats where the logged-in user is a member.
    async getUserChats(userId: number) {
        return this.prisma.chat.findMany({
            where: {
                members: {
                    some: {
                        userId,
                    },
                },
            },
            include: this.getChatInclude(),
            orderBy: {
                // Newest chats first, so recent conversations appear at the top.
                createdAt: 'desc',
            },
        });
    }

    // Creates a one-to-one chat between the logged-in user and another user.
    async createPrivateChat(currentUserId: number, otherUserId: number) {
        // A user should not be able to start a chat with themselves.
        if (currentUserId === otherUserId) {
            throw new BadRequestException('You cannot create a chat with yourself');
        }

        // Make sure the user we want to chat with really exists.
        const otherUser = await this.prisma.user.findUnique({
            where: {
                id: otherUserId,
            },
        });

        if (!otherUser) {
            throw new NotFoundException('Other user not found');
        }

        // Check if these two users already have a private chat.
        const existingChat = await this.prisma.chat.findFirst({
            where: {
                isGroup: false,
                AND: [
                    {
                        members: {
                            some: {
                                userId: currentUserId,
                            },
                        },
                    },
                    {
                        members: {
                            some: {
                                userId: otherUserId,
                            },
                        },
                    },
                ],
            },
            include: this.getChatInclude(),
        });

        if (existingChat) {
            // Reuse the existing chat instead of creating a duplicate.
            return existingChat;
        }

        // Create the private chat and add both users as chat members.
        return this.prisma.chat.create({
            data: {
                isGroup: false,
                members: {
                    create: [
                        {
                            userId: currentUserId,
                        },
                        {
                            userId: otherUserId,
                        },
                    ],
                },
            },
            include: this.getChatInclude(),
        });
    }

    // Defines which related data should come back with each chat.
    private getChatInclude() {
        return {
            members: {
                include: {
                    user: {
                        select: {
                            id: true,
                            username: true,
                            email: true,
                        },
                    },
                },
            },
            messages: {
                orderBy: {
                    // Get the newest message first.
                    createdAt: 'desc' as const,
                },
                // Only return the latest message for the chat preview.
                take: 1,
            },
        };
    }
}
