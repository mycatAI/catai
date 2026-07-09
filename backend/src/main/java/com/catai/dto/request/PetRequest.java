package com.catai.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PetRequest {

    @NotBlank(message = "宠物名称不能为空")
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
}
