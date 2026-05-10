import { Module } from '@nestjs/common';
import { ChatsController } from './chats.controller';
import { ChatsService } from './chats.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  // PrismaModule gives this module access to the database service.
  imports: [PrismaModule],
  // Controller defines the HTTP routes for chats.
  controllers: [ChatsController],
  // Service contains the chat business logic and database calls.
  providers: [ChatsService],
})
export class ChatsModule {}
