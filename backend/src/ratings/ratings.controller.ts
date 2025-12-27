import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { RatingsService } from './ratings.service';

@Controller('ratings')
export class RatingsController {
    constructor(private readonly ratingsService: RatingsService) { }

    @Get('leaderboard')
    getLeaderboard() {
        return this.ratingsService.getLeaderboard();
    }

    @Get(':nganyaId')
    async getRatings(@Param('nganyaId') nganyaId: string) {
        return this.ratingsService.findByNganya(nganyaId);
    }

    @Post(':nganyaId')
    async addReview(
        @Param('nganyaId') nganyaId: string,
        @Body() body: { rating: number; comment?: string },
    ) {
        return this.ratingsService.create(nganyaId, body.rating, body.comment);
    }
}
