import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { RatingsService } from './ratings.service';

@Controller('ratings')
export class RatingsController {
    constructor(private readonly ratingsService: RatingsService) { }

    @Get(':nganyaId')
    async getReviews(@Param('nganyaId') nganyaId: string) {
        const reviews = await this.ratingsService.findByNganya(nganyaId);
        const avg = await this.ratingsService.getAverageRating(nganyaId);
        return { average_rating: avg, reviews };
    }

    @Post(':nganyaId')
    async addReview(
        @Param('nganyaId') nganyaId: string,
        @Body() body: { rating: number; comment?: string },
    ) {
        return this.ratingsService.create(nganyaId, body.rating, body.comment);
    }
}
