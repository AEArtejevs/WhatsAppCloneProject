import { Module } from '@nestjs/common';
import { MessagesController } from './messages.controller';
import { MessagesService } from './messages.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
    // PrismaModule gives this module access to the database service.
    imports: [PrismaModule],
    // Controller defines the HTTP routes for chat messages.
    controllers: [MessagesController],
    // Service contains the message business logic and database calls.
    providers: [MessagesService],
})
export class MessagesModule { }
