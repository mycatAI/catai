package com.catai.controller;

import com.catai.dto.request.PetRequest;
import com.catai.dto.response.ApiResponse;
import com.catai.dto.response.PetResponse;
import com.catai.service.PetService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pets")
@RequiredArgsConstructor
public class PetController {

    private final PetService petService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<PetResponse>>> getPets(Authentication auth) {
        String userId = auth.getName();
        List<PetResponse> pets = petService.getUserPets(userId);
        return ResponseEntity.ok(ApiResponse.success(pets));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<PetResponse>> getPet(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        PetResponse pet = petService.getPet(id, userId);
        return ResponseEntity.ok(ApiResponse.success(pet));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<PetResponse>> createPet(@Valid @RequestBody PetRequest req,
                                                               Authentication auth) {
        String userId = auth.getName();
        PetResponse pet = petService.createPet(userId, req);
        return ResponseEntity.ok(ApiResponse.success(pet));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<PetResponse>> updatePet(@PathVariable String id,
                                                               @Valid @RequestBody PetRequest req,
                                                               Authentication auth) {
        String userId = auth.getName();
        PetResponse pet = petService.updatePet(id, userId, req);
        return ResponseEntity.ok(ApiResponse.success(pet));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePet(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        petService.deletePet(id, userId);
        return ResponseEntity.ok(ApiResponse.success("删除成功", null));
    }
}
