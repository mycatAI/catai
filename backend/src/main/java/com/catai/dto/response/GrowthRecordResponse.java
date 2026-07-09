package com.catai.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GrowthRecordResponse {

    private String id;
    private String petId;
    private String date;
    private Double weight;
    private Double height;
    private String photo;
    private String notes;
    private String type;
    private String createTime;
}
