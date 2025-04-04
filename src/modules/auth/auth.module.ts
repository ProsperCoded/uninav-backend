import { Global, Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from 'src/modules/user/user.module';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { getJwtConfig } from 'src/utils/config/jwt.config';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JWT_SYMBOL } from 'src/utils/config/constants.config';
import { LocalStrategy } from 'src/modules/auth/strategies/local.strategy';
import { AuthRepository } from './auth.repository';
import { DrizzleModule } from 'src/modules/drizzle/drizzle.module';

@Global()
@Module({
  imports: [
    DrizzleModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => getJwtConfig(configService),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    AuthRepository,
    LocalStrategy,
    {
      provide: JWT_SYMBOL,
      useExisting: JwtService,
    },
  ],
  exports: [
    {
      provide: JWT_SYMBOL,
      useExisting: JwtService,
    },
    AuthService,
    AuthRepository,
  ],
})
export class AuthModule {}
