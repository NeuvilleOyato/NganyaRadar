import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { DriverService } from '../driver/driver.service';
import { NganyaService } from '../nganya/nganya.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
    constructor(
        private driverService: DriverService,
        private nganyaService: NganyaService,
        private jwtService: JwtService,
    ) { }

    async validateDriver(phone_number: string, pass: string): Promise<any> {
        const driver = await this.driverService.findByPhoneWithPassword(phone_number);
        if (driver && (await bcrypt.compare(pass, driver.password_hash))) {
            const { password_hash, ...result } = driver;
            return result;
        }
        return null;
    }

    async login(driver: any) {
        const payload = { username: driver.phone_number, sub: driver.id, role: 'driver' };
        return {
            access_token: this.jwtService.sign(payload),
            driver: {
                id: driver.id,
                full_name: driver.full_name,
                assigned_nganya_id: driver.assigned_nganya_id,
            }
        };
    }

    async register(phone_number: string, pass: string, full_name: string, nganya_name: string) {
        const hashedPassword = await bcrypt.hash(pass, 10);

        let assigned_nganya = null;
        if (nganya_name) {
            assigned_nganya = await this.nganyaService.create({
                name: nganya_name,
                is_active: true
            });
        }

        return this.driverService.create({
            phone_number,
            password_hash: hashedPassword,
            full_name,
            assigned_nganya: assigned_nganya || undefined,
            assigned_nganya_id: assigned_nganya ? assigned_nganya.id : undefined
        });
    }
}
