package com.catai.dto.request;

import lombok.Data;

@Data
public class GrowthRecordRequest {

    private String date;
    private Double weight;
    private Double height;
    private String photo;
    private String notes;
    private String type;
}
