package com.openclassroom.pocchat.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;

import com.openclassroom.pocchat.dto.ChatMessage;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;


@RestController
public class ChatController {

    public List<ChatMessage> chatMessageSaved = new ArrayList<>();

    @GetMapping("/api/messages")
    public List<ChatMessage> getMessage(){
        return chatMessageSaved;
    }

    @DeleteMapping("/api/messages")
    public void removeMessage(){
        this.chatMessageSaved.clear();
    }


    @MessageMapping("/sendMessage")
    @SendTo("/topic/messages")
    public ChatMessage sendMessage(@Payload ChatMessage chatMessage, SimpMessageHeaderAccessor headerAccessor
    ) {
        this.chatMessageSaved.add(chatMessage);
        return chatMessage;
    }

    @MessageMapping("/removeUser")
    @SendTo("/topic/messages")
    public ChatMessage removeUser(@Payload ChatMessage chatMessage, SimpMessageHeaderAccessor headerAccessor
    ) {
        this.chatMessageSaved.add(chatMessage);
        return chatMessage;
    }

    @MessageMapping("/addUser")
    @SendTo("/topic/messages")
    public ChatMessage  addUser(@Payload ChatMessage chatMessage, SimpMessageHeaderAccessor headerAccessor
    ) {
        this.chatMessageSaved.add(chatMessage);
        return chatMessage;
    }





}

