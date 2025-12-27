import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RatingsService } from './ratings.service';
import { RatingsController } from './ratings.controller';
import { Review } from './review.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Review])],
    providers: [RatingsService],
    controllers: [RatingsController],
    exports: [RatingsService],
})
export class RatingsModule { }
