import {Injectable} from "@angular/core";
import {Http} from "@angular/http";
import {RequestMethod} from '@angular/http';
import {JwtService} from "./jwt.service"

@Injectable()
export class RequestService {

    constructor(private http: Http, private jwtService: JwtService) {
    }

    request(requestUrl: string, requestMethod: string | RequestMethod, bodyData?: Object): Promise<any> {
        return this.jwtService.requestWithJwt(requestUrl, requestMethod, bodyData);
    }

}
