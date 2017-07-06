import {Component, enableProdMode} from "@angular/core";
import {JwtService} from "./shared/jwt.service";

enableProdMode();

@Component({
    selector: 'conference',
    templateUrl: 'app/app.component.html'
})

export class AppComponent {
    title = 'Microprofile Conference';

    constructor(private jwtService: JwtService) {
        jwtService.extractTokenAndSetInStorage();
    }
}