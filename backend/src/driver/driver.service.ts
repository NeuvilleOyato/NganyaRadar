import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Driver } from './driver.entity';

@Injectable()
export class DriverService {
    constructor(
        @InjectRepository(Driver)
        private driverRepository: Repository<Driver>,
    ) { }

    async findAll(): Promise<Driver[]> {
        return this.driverRepository.find({ relations: ['assigned_nganya'] });
    }

    async findOne(id: string): Promise<Driver> {
        const driver = await this.driverRepository.findOne({
            where: { id },
            relations: ['assigned_nganya'],
        });
        if (!driver) {
            throw new NotFoundException(`Driver with ID ${id} not found`);
        }
        return driver;
    }

    async findByPhone(phone_number: string): Promise<Driver | null> {
        return this.driverRepository.findOne({ where: { phone_number } });
    }

    async findByPhoneWithPassword(phone_number: string): Promise<Driver | null> {
        return this.driverRepository.findOne({
            where: { phone_number },
            select: ['id', 'phone_number', 'password_hash', 'full_name', 'is_active', 'assigned_nganya_id', 'reset_token', 'reset_token_expiry'],
        });
    }

    async create(data: Partial<Driver>): Promise<Driver> {
        const driver = this.driverRepository.create(data);
        return this.driverRepository.save(driver);
    }

    async update(driverOrId: string | Driver, data?: Partial<Driver>): Promise<Driver> {
        if (typeof driverOrId === 'string') {
            await this.driverRepository.update(driverOrId, data!);
            return this.findOne(driverOrId);
        } else {
            return this.driverRepository.save(driverOrId);
        }
    }

    async remove(id: string): Promise<void> {
        await this.driverRepository.delete(id);
    }
}
