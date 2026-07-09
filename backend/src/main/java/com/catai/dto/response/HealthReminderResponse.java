package com.catai.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthReminderResponse {

    private String id;
    private String petId;
    private String type;
    private String title;
    private String date;
    private String time;
    private String repeatCycle;
    private Boolean enabled;
    private String notes;
    private String createTime;
}
