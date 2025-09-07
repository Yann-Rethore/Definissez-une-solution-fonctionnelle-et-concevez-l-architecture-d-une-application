import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ChatComponent } from './chat/chat.component';

@Component({
  selector: 'app-root',
   imports: [ChatComponent],
  template: `<app-chat></app-chat>`
})
export class AppComponent {
  title = 'poc';
 constructor() {
    // You can inject the ChatService here if needed
    // this.chatService = service;
    localStorage.clear();

 }
}
