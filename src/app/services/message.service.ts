

import {Injectable} from "@angular/core";
import {HttpClient} from "@angular/common/http";
import { ChatMessage } from "./websocket.sevice";


@Injectable({
  providedIn: 'root'
})

export class MessageService {

  private pathService = 'http://localhost:8080/api/messages';
  public constructor(private http: HttpClient) {
  }

  public getMessages() {
    return this.http.get<ChatMessage[]>(`${this.pathService}`);

  }

  public clearMessages() {
    return this.http.delete<any>(`${this.pathService}`);

  }

}
