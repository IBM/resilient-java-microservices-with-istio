import {Injectable} from "@angular/core";
import {Http} from "@angular/http";
import {RequestOptions} from '@angular/http';
import {RequestMethod} from '@angular/http';
import {Headers} from '@angular/http';
import {Router} from "@angular/router";

@Injectable()
export class JwtService {

    ACCESS_TOKEN: string = "access_token";
    EXPIRES_IN: string = "expires_in";
    EXPIRES_AT: string = "expires_at";
    SERVICE: string = "requested_service";
    REQUESTED_SERVICE_COOKIE: string = "liber8-requested-service"

    STATE_LENGTH: number = 20;
    DEFAULT_EXP_SEC: number = 7200;
    REQUESTED_SERVICE_COOKIE_EXP_SEC: number = 300;

    constructor(private http: Http, private router: Router) { }

    extractTokenAndSetInStorage(): boolean {
        // Using OAuth implicit flow, the requisite token will be included in the fragment portion of the URL
        var token = this.extractFromFragment(this.ACCESS_TOKEN);
        if (!token) {
            return false;
        }
        // Token found in URI fragment
        var isTokenNew = false;
        var existingToken = this.getFromStorage(this.ACCESS_TOKEN);
        if (existingToken && existingToken === token) {
            // Same token already exists in storage
            isTokenNew = false;
        } else {
            this.setInStorage(this.ACCESS_TOKEN, token);

            // Determine when token expires and record expiration date in storage
            this.setTokenExpiration();

            isTokenNew = true;
        }

        // Re-route to last requested service
        this.rerouteToRequestedService();

        return isTokenNew;
    }

    requestWithJwt(requestUrl: string, requestMethod: string | RequestMethod, bodyData?: Object): Promise<any> {
        // Get the token from storage. If no token in storage, go request a new one.
        var token = this.getToken();
        if (!token) {
            return new Promise(resolve => {
                resolve(this.requestJwt());
            });
        }

        // Add any provided HTTP body data to the body of the request
        var requestBody = {};
        if (bodyData) {
            Object.keys(bodyData).forEach((key) => requestBody[key] = bodyData[key]);
        }
        // Include the JWT in the Authorization header of the request
        var requestHeaders = new Headers({
            'Authorization' : "Bearer " + token,
            'Content-Type' : "application/json"
        });
        return this.http.request(requestUrl, new RequestOptions({
                method: requestMethod,
                headers : requestHeaders,
                body : requestBody
            })).toPromise();
    }

    private getToken(): string {
        // Check if token already exists in storage
        var token = this.getFromStorage(this.ACCESS_TOKEN);
        if (!token) {
            return undefined;
        }
        // Token found in storage - check if it might be expired
        var expiresAt = Number(this.getFromStorage(this.EXPIRES_AT));
        if (expiresAt) {
            var now = new Date();
            if (now.getTime() > expiresAt) {
                // Token has likely expired
                return undefined;
            }
        }
        return token;
    }

    private requestJwt(): Promise<any> {
        // Record what service was requested so that we can re-navigate back to that service when we return
        this.storeRequestedService();

        // Set all parameters required or recommended by OAuth implicit flow
        var redirectUri = this.getRedirectUri();
        var state = this.generateState(this.STATE_LENGTH);
        var params = {
            "response_type" : "token",
            "client_id" : "rp",
            "redirect_uri" : redirectUri,
            "state" : state,
            "scope" : "openid email"
        };
        var queryString = "?";
        for (var param in params) {
            queryString += encodeURIComponent(param) + "=";
            queryString += encodeURIComponent(params[param]) + "&";
        }

        var port = 31005;
        var authzUrl = location.protocol + "//" + location.hostname + ":" + port + "/oidc/endpoint/OP/authorize";
        var requestUrl = authzUrl + queryString;

        return new Promise(resolve => {
            window.location.replace(requestUrl);
        });
    }

    private rerouteToRequestedService(): void {
        var lastRequestedService = this.getCookieValue(this.REQUESTED_SERVICE_COOKIE);
        this.deleteCookie(this.REQUESTED_SERVICE_COOKIE);
        if (lastRequestedService) {
            this.router.navigate([lastRequestedService]);
        }
    }

    private storeRequestedService(): void {
        var service = location.pathname;
        if (service.indexOf("?") > 0) {
            service = service.substring(0, service.indexOf("?"));
        }
        if (service.indexOf("#") > 0) {
            service = service.substring(0, service.indexOf("#"));
        }
        this.setCookie(this.REQUESTED_SERVICE_COOKIE, service, this.REQUESTED_SERVICE_COOKIE_EXP_SEC);
    }

    private setTokenExpiration() {
        // Determine when token expires and record expiration date in storage
        var expiresIn = parseInt(this.extractFromFragment(this.EXPIRES_IN));
        if (!expiresIn) {
            expiresIn = this.DEFAULT_EXP_SEC;
        }
        var now = Date.now();
        var expiresAt = now + (expiresIn * 1000);
        this.setInStorage(this.EXPIRES_AT, expiresAt.toString());
    }

    private extractFromFragment(param: string): string {
        var result = undefined;
        var params = this.getFragmentParameters();
        if (params) {
            result = params[param];
        }
        return result;
    }

    private getFragmentParameters() {
        var fragment = location.hash;
        if (!fragment || fragment === "" || fragment === "#") {
            return undefined;
        }
        return this.getParameters(fragment.substr(1));
    }

    private getParameters(queryOrFragmentString: string) {
        var params = {};
        var paramObjs = queryOrFragmentString.split("&");
        for (var param in paramObjs) {
            var entry = paramObjs[param].split("=");
            var key = entry[0];
            var value = entry[1];
            params[key] = value;
        }
        return params;
    }

    private getRedirectUri(): string {
        // Redirect back to root context since Angular mixed with OAuth redirects don't work well with deep linking
        var redirectUri = location.protocol + "//" + location.hostname;
        return redirectUri;
    }

    private generateState(length: number): string {
        var text = "";
        var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for (var i = 0; i < length; i++ ) {
            text = text + chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return text;
    }

    private setInStorage(param: string, value: string): void {
        window.localStorage.setItem(param, value);
    }

    private getFromStorage(param: string): string {
        return window.localStorage.getItem(param);
    }

    private setCookie(name: string, value: string, expireInMinutes: number): void {
        var d = new Date();
        d.setTime(d.getTime() + (expireInMinutes * 60 * 1000));
        var expires = "expires="+ d.toUTCString();
        document.cookie = name + "=" + value + ";" + expires + ";path=/";
    }

    private getCookieValue(cookieName: string): string {
        var cookies = document.cookie;
        if (!cookies || cookies === "") {
            return undefined;
        }
        var cookiesSplit = cookies.split(";");
        for (var entry in cookiesSplit) {
            var cookie = cookiesSplit[entry];
            var split = cookie.split("=");
            var name = split[0].trim();
            if (name === cookieName) {
                return split[1].trim();
            }
        }
        return undefined;
    }

    private deleteCookie(name: string): void {
        document.cookie = name + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
    }
}
