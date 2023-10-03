package com.example.demo.controllers;

import com.example.demo.FedrampAutomationValidator;

import net.sf.saxon.s9api.SaxonApiException;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.io.File;

@RestController
@RequestMapping("/api/validation")
public class ValidationController {

    private final FedrampAutomationValidator validator;
    /** Location of baseline 800-53rev4 definitions */
    private static final String BASELINES_PATH = "src/main/java/com/example/demo/content/rev4/baselines/xml";

    /** Location of resource values */
    private static final String RESOURCES_PATH = "src/main/java/com/example/demo/content/rev4/resources/xml";

    /** compiled Schematron XSLT path for SSP resource values */
    private static final String SSP_RESOURCE = "src/main/java/com/example/demo/rules/rev4/ssp.sch.xsl";

    public ValidationController() {
        try {
            this.validator = new FedrampAutomationValidator(new File(SSP_RESOURCE).getAbsolutePath(),
                    new File(BASELINES_PATH).getAbsolutePath(),
                    new File(RESOURCES_PATH).getAbsolutePath());
        } catch (SaxonApiException e) {
            throw new RuntimeException("Error initializing FedrampAutomationValidator", e);
        }
    }

    @PostMapping(value = "/validate", consumes = { "multipart/form-data" })
    public ResponseEntity<List<Map<String, String>>> validateOscalDocument(@RequestPart("file") MultipartFile file) {
        try {
            // Convert the multipart file to a temporary file
            File tempFile = File.createTempFile("temp", "oscal");
            file.transferTo(tempFile);

            List<Map<String, String>> validationResults = validator.validateOscalDocument(tempFile.getAbsolutePath());
            tempFile.delete(); // Clean up the temporary file

            return ResponseEntity.ok(validationResults);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
}
