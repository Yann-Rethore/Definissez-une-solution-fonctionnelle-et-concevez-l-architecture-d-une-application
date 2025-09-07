package com.openclassroom.pocchat.configuration;


import com.openclassroom.pocchat.dto.ChatMessage;
import com.openclassroom.pocchat.dto.MessageType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
@RequiredArgsConstructor
public class WebSocketEventListener {

  private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

  private final SimpMessageSendingOperations messagingTemplate;
  private final Set<String> activeSessions = ConcurrentHashMap.newKeySet();


  @EventListener
  public void handleSessionConnected(SessionConnectEvent event) {
    String sessionId = event.getMessage().getHeaders().get("simpSessionId").toString();
    activeSessions.add(sessionId);
    sendConnectionCount();
  }

  @EventListener
  public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
    StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
    if (headerAccessor.getSessionAttributes() == null) {
      String username = (String) headerAccessor.getSessionAttributes().get("username");
      if (username != null) {
        logger.info("user disconnected: {}", username);
        var chatMessage = ChatMessage.builder()
          .sender(username)
                .type(MessageType.LEAVE)
          .build();
        String sessionId = event.getSessionId();
        activeSessions.remove(sessionId);
        this.sendConnectionCount();

        messagingTemplate.convertAndSend("/topic/messages", chatMessage);
      }
    }
  }

  private void sendConnectionCount() {
    int count = activeSessions.size();

    messagingTemplate.convertAndSend("/topic/connections", count);
  }

}
