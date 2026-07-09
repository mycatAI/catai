package com.catai.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PetResponse {

    private String id;
    private String userId;
    private String name;
    private String species;
    private String breed;
    private String birthDate;
    private String gender;
    private String avatar;
    private Double weight;
    private Double height;
    private String color;
    private String notes;
    private String createTime;
    private String updateTime;
}
