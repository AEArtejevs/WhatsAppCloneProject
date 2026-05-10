import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      // Read the token from: Authorization: Bearer <token>
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      // Reject expired tokens automatically.
      ignoreExpiration: false,
      // This must match the secret used when signing tokens in AuthModule.
      secretOrKey: 'dev_secret_change_later',
    });
  }

  // Runs after Passport confirms the JWT is valid.
  async validate(payload: { sub: number; email: string }) {
    return {
      // This object becomes request.user in protected controllers.
      userId: payload.sub,
      email: payload.email,
    };
  }
}
