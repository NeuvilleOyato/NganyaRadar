import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Nganya } from './nganya.entity';

@Injectable()
export class NganyaService {
    constructor(
        @InjectRepository(Nganya)
        private nganyaRepository: Repository<Nganya>,
    ) { }

    findAll(): Promise<Nganya[]> {
        return this.nganyaRepository.find();
    }

    async findOne(id: string): Promise<Nganya> {
        const nganya = await this.nganyaRepository.findOneBy({ id });
        if (!nganya) {
            throw new NotFoundException(`Nganya with ID ${id} not found`);
        }
        return nganya;
    }

    async create(data: Partial<Nganya>): Promise<Nganya> {
        const nganya = this.nganyaRepository.create(data);
        return this.nganyaRepository.save(nganya);
    }

    async update(id: string, data: Partial<Nganya>): Promise<Nganya> {
        await this.nganyaRepository.update(id, data);
        return this.findOne(id);
    }

    async updateLocation(id: string, lat: number, lng: number): Promise<Nganya | null> {
        const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        if (!uuidRegex.test(id)) {
            console.warn(`Invalid Nganya ID format: ${id}. Skipping location update.`);
            return null;
        }

        await this.nganyaRepository.update(id, {
            last_latitude: lat,
            last_longitude: lng,
            last_updated: new Date(),
        });
        return this.findOne(id);
    }

    async remove(id: string): Promise<void> {
        await this.nganyaRepository.delete(id);
    }
}
