import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Nganya } from '../nganya/nganya.entity';

@Entity()
export class Driver {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    phone_number: string;

    @Column({ select: false })
    password_hash: string;

    @Column({ nullable: true })
    full_name: string;

    @ManyToOne(() => Nganya, { nullable: true })
    @JoinColumn({ name: 'assigned_nganya_id' })
    assigned_nganya: Nganya;

    @Column({ nullable: true })
    assigned_nganya_id: string;

    @Column({ default: true })
    is_active: boolean;

    @Column({ nullable: true, select: false })
    reset_token: string;

    @Column({ type: 'timestamp', nullable: true, select: false })
    reset_token_expiry: Date;
}
