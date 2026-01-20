import { Controller, Post, Body, UseGuards, Request, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    @Post('login')
    async login(@Body() req: any) {
        const driver = await this.authService.validateDriver(req.phone_number, req.password);
        if (!driver) {
            return { message: 'Invalid credentials' };
        }
        return this.authService.login(driver);
    }

    @Post('register')
    async register(@Body() req: any) {
        return this.authService.register(req.phone_number, req.password, req.full_name, req.nganya_name);
    }

    @UseGuards(AuthGuard('jwt'))
    @Get('profile')
    getProfile(@Request() req: any) {
        return req.user;
    }

    @Post('forgot-password')
    async forgotPassword(@Body() body: { phone_number: string }) {
        return this.authService.forgotPassword(body.phone_number);
    }

    @Post('reset-password')
    async resetPassword(@Body() body: { phone_number: string; otp: string; new_password: string }) {
        return this.authService.resetPassword(body.phone_number, body.otp, body.new_password);
    }
}
