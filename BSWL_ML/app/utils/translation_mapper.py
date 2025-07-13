import json

class TranslationMapper:
    def __init__(self, label_mappings):
        self.label_mappings = label_mappings
        self.reverse_mapping = self._create_reverse_mapping()
    
    def _create_reverse_mapping(self):
        return {
            v['en']: k for k, v in self.label_mappings.items()
        }
    
    def get_english(self, class_id):
        return self.label_mappings.get(str(class_id), {}).get('en', 'unknown')
    
    def get_hindi(self, class_id):
        return self.label_mappings.get(str(class_id), {}).get('hi', 'अज्ञात')
    
    def get_class_id(self, english_text):
        return self.reverse_mapping.get(english_text, -1)
    
    def translate_sequence(self, sequence):
        return [
            {
                "english": self.get_english(class_id),
                "hindi": self.get_hindi(class_id),
                "class_id": class_id
            }
            for class_id in sequence
        ]