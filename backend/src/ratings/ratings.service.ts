import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review } from './review.entity';

@Injectable()
export class RatingsService {
    constructor(
        @InjectRepository(Review)
        private reviewRepository: Repository<Review>,
    ) { }

    async create(nganyaId: string, rating: number, comment?: string): Promise<Review> {
        const review = this.reviewRepository.create({
            nganya_id: nganyaId,
            rating,
            comment,
        });
        return this.reviewRepository.save(review);
    }

    async findByNganya(nganyaId: string): Promise<Review[]> {
        return this.reviewRepository.find({
            where: { nganya_id: nganyaId },
            order: { created_at: 'DESC' },
            take: 20, // Limit to last 20 reviews for low data
        });
    }

    async getAverageRating(nganyaId: string): Promise<number> {
        const { avg } = await this.reviewRepository
            .createQueryBuilder('review')
            .select('AVG(review.rating)', 'avg')
            .where('review.nganya_id = :nganyaId', { nganyaId })
            .getRawOne();

        return parseFloat(avg) || 0;
    }
}
