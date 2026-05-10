import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  // PrismaModule gives this module access to the database service.
  imports: [PrismaModule],
  // Controller defines the HTTP routes for users.
  controllers: [UsersController],
  // Service contains the user business logic and database calls.
  providers: [UsersService],
})
export class UsersModule {}
