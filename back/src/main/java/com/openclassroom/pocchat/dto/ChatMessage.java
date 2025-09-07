package com.openclassroom.pocchat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@Builder
public class ChatMessage {
    private String sender;
    private String content;
    private MessageType type;
    private Date timestamp;
}
