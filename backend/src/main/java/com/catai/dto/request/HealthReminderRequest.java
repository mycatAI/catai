package com.catai.dto.request;

import lombok.Data;

@Data
public class HealthReminderRequest {

    private String type;
    private String title;
    private String date;
    private String time;
    private String repeatCycle;
    private Boolean enabled;
    private String notes;
}
