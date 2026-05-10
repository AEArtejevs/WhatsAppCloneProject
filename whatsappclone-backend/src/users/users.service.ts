import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
    constructor(private readonly prisma: PrismaService) { }

    // Gets all users except the logged-in user, so they can be shown as contacts.
    async getContacts(currentUserId: number) {
        return this.prisma.user.findMany({
            where: {
                id: {
                    // Do not show the current user in their own contacts list.
                    not: currentUserId,
                },
            },
            select: {
                // Only return public user fields, never the password hash.
                id: true,
                username: true,
                email: true,
                createdAt: true,
            },
            orderBy: {
                // Sort contacts alphabetically by username.
                username: 'asc',
            },
        });
    }
}
