import {Injectable} from "@angular/core";
import {Http} from "@angular/http";
import {RequestOptions} from '@angular/http';
import {RequestMethod} from '@angular/http';
import {Headers} from '@angular/http';

@Injectable()
export class RequestService {

    constructor(private http: Http) {
    }

    request(requestUrl: string, requestMethod: string | RequestMethod, bodyData?: Object): Promise<any> {
        // Add any provided HTTP body data to the body of the request
        var requestBody = {};
        if (bodyData) {
            Object.keys(bodyData).forEach((key) => requestBody[key] = bodyData[key]);
            console.log("Request body data: " + JSON.stringify(requestBody, null, 3));
        }
        return this.http.request(requestUrl, new RequestOptions({
            method: requestMethod,
            body : requestBody
        })).toPromise();
    }

}
