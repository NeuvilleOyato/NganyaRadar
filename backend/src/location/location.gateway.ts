import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    MessageBody,
    ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { NganyaService } from '../nganya/nganya.service';
import { UseGuards } from '@nestjs/common';
// import { WsAuthGuard } from '../auth/ws-auth.guard'; // To be implemented or handled manually

@WebSocketGateway({
    cors: {
        origin: '*',
    },
})
export class LocationGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    constructor(private readonly nganyaService: NganyaService) { }

    handleConnection(client: Socket) {
        console.log(`Client connected: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        console.log(`Client disconnected: ${client.id}`);
    }

    // Driver sends location updates
    // @UseGuards(WsAuthGuard) // Complex to set up WsAuthGuard quickly, let's assume loose auth for MVP or send token in payload
    @SubscribeMessage('updateLocation')
    async handleLocationUpdate(
        @MessageBody() data: { nganyaId: string; lat: number; lng: number },
        @ConnectedSocket() client: Socket,
    ) {
        console.log(`Location update received from ${client.id}:`, data);
        // In production, verify user is the driver of this nganya
        // await this.nganyaService.validateDriver(client, data.nganyaId);

        // Update DB
        const nganya = await this.nganyaService.updateLocation(data.nganyaId, data.lat, data.lng);

        // Broadcast to everyone with full info
        this.server.emit('nganyaLocationUpdate', {
            ...data,
            name: nganya?.name || 'Unknown'
        });

        return { status: 'ok' };
    }

    // Passengers subscribe to updates (optional if we just broadcast all)
    @SubscribeMessage('subscribeToNganya')
    handleSubscribe(
        @MessageBody() data: { nganyaId: string },
        @ConnectedSocket() client: Socket,
    ) {
        client.join(`nganya_${data.nganyaId}`);
        return { status: 'joined', nganyaId: data.nganyaId };
    }

    @SubscribeMessage('updateServiceStatus')
    async handleServiceStatusUpdate(
        @MessageBody() data: { nganyaId: string; isActive: boolean },
    ) {
        console.log(`Service status update:`, data);
        await this.nganyaService.update(data.nganyaId, { is_active: data.isActive });
        this.server.emit('nganyaStatusUpdate', data);
        return { status: 'ok' };
    }
}
