import { Injectable, signal } from '@angular/core';
import { Subject } from 'rxjs';
import SockJS from 'sockjs-client';
import { Client, IMessage } from '@stomp/stompjs';
import { MessageService } from './message.service';

export interface ChatMessage {
  id?: string;
  sender: string | null;
  content: string;
  type: 'CHAT' | 'JOIN' | 'LEAVE' | 'CLEAR';
  timestamp?: Date;
}

@Injectable({
  providedIn: 'root'
})
export class WebsocketService {
  
  //The STOMP client instance used for WebSocket communication.
  private stompClient: any;

  //Subject to emit incoming chat messages to subscribers.
  private messageSubject: Subject<ChatMessage> = new Subject<ChatMessage>();

  //Signal to track the connection status to the WebSocket server.
  private readonly _isConnected = signal(false);

  //Readonly signal to expose the connection status.
  readonly isConnected = this._isConnected.asReadonly();


  constructor(public messageService: MessageService) {
  }

  /**
   * 
   * @param message chat message to send
   */
  public sendsMessage(message: ChatMessage) {
    this.messageSubject.next(message);
  }

  /**
   * Performs the connection to the WebSocket server using STOMP protocol.
   * @param username username of the user connecting
   * @returns 
   */
  connect(username: string): Promise<void> {
    return new Promise((resolve, reject) => {

      this.stompClient = new Client({
        webSocketFactory: () => new SockJS('http://localhost:8080/ws') as WebSocket,
        connectHeaders: {},
        debug: (str) => {
          console.log('STOMP: ' + str);
        },

        reconnectDelay: 5000,
        heartbeatIncoming: 4000,
        heartbeatOutgoing: 4000,

        onConnect: (frame) => {
          this._isConnected.set(true);
          localStorage.setItem('username', username);
          this.receiveMessageFromWebsocketServer();
          this.numberOfConnexion();
          this.sendJoinMessage(username);
          resolve();
        },

        onDisconnect: (frame) => {
          this._isConnected.set(false);
        },

        onStompError: (frame) => {
          console.error('Broker reported error: ' + frame.headers['message']);
          reject(new Error(frame.headers['message'] || 'Connection failed'));
        },

        onWebSocketError: (error) => {
          console.error('WebSocket error: ', error);
          reject(error);
        }
      });
      this.stompClient.activate();
    });
  }

  /**
   * Subscribes to the /topic/messages endpoint to receive messages from the server.
   */
  public receiveMessageFromWebsocketServer(){
     this.stompClient?.subscribe('/topic/messages', (message: IMessage) => {
            const chatMessage: ChatMessage = JSON.parse(message.body);
            this.messageSubject.next(chatMessage);

            if (chatMessage.type === 'JOIN') {
              this.messageService.getMessages().subscribe((messages: ChatMessage[]) => {
                this.messageSubject.next({ sender: null, content: '', type: 'CLEAR', timestamp: new Date() });
                messages.forEach(message => this.messageSubject.next(message));
                console.log(messages);
              });
            }
    });
  }
    public numberOfConnexion(){
     this.stompClient?.subscribe('/topic/connections', (message: IMessage) => {
            const count: any = JSON.parse(message.body);
           // this.messageSubject.next(chatMessage);
           console.log(count)

            
    });
  }

  

  /**
   * Disconnects from the WebSocket server and cleans up resources.
   */
  public disconnect(): void {
    
    if (this.stompClient?.connected) {
      this.sendLeaveMessage();
    }

    if (this.stompClient) {
      this.stompClient.deactivate();
      this.stompClient = null;
    }
    this._isConnected.set(false);
    localStorage.removeItem('username');
  }

  /**
   * 
   * @returns Observable to subscribe to receive messages from the server
   */
  public getMessages(): any {
    return this.messageSubject.asObservable();
  }

  /**
   * 
   * @param message message to send to the server
   * @returns 
   */
  public sendMessage(message: any) {

    if (!this.stompClient?.connected) {
      return;
    }

    this.stompClient.publish({
      destination: '/app/sendMessage',
      body: JSON.stringify(message)
    });
  }


  private sendLeaveMessage(): void {
    if (!this.stompClient?.connected) return;

    const message: ChatMessage = {
      sender: "robot",
      content: `${localStorage.getItem('username')} a quitté le chat`,
      type: 'LEAVE',
      timestamp: new Date()
    };

    this.stompClient.publish({
      destination: '/app/removeUser',
      body: JSON.stringify(message)
    });
  }




  // clearMessages(): void {
  //   console.log('Messages cleared');
  //   this.messageSubject.next({ sender: '', content: '', type: 'CLEAR', timestamp: new Date() });
  //   this.messageService.clearMessages().subscribe(() => {
  //     console.log('Messages cleared on server');
  //   });

  // }


  private sendJoinMessage(username: string): void {
    if (!this.stompClient?.connected) return;

    const message: ChatMessage = {
      sender: "robot",
      content: `${username} a rejoint le chat`,
      type: 'JOIN',
      timestamp: new Date()
    };

    this.stompClient.publish({
      destination: '/app/addUser',
      body: JSON.stringify(message)
    })
  }
}
