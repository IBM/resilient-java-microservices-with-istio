import {Component, enableProdMode} from "@angular/core";
import {CookieService} from 'angular2-cookie/core';

enableProdMode();

@Component({
    selector: 'conference',
    templateUrl: 'app/app.component.html'
})

export class AppComponent {
    title = 'Microprofile Conference';
    loginU = false;
    emails: string;
    email: string;
    firstTime = true;

    constructor(private _cookieService:CookieService){
    	let currEmail = this._cookieService.get("email");
    	if(currEmail){
    		this.firstTime = false;
    		this.email = currEmail.slice(0);
    		this.loginU = true;
    	}
    }

    login(emails: string): void {
     	this.loginU = true;
     	this.emails = emails;
     	this._cookieService.put("email", emails);
    }

    logout(): void {
    	this.loginU = false;
    	this.firstTime = true;
    	this._cookieService.remove("email");
    	
    }
}