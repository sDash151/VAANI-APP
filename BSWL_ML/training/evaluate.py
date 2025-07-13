import torch
import numpy as np
from sklearn.metrics import confusion_matrix, classification_report
from torch.utils.data import DataLoader
from .dataset import ISLDataset
from app.models.isl_model import SignLanguageTransformer
from app.core.config import settings
import matplotlib.pyplot as plt
import seaborn as sns
import json


def evaluate_model(model, test_loader, device="cuda"):
    model.eval()
    all_preds = []
    all_labels = []
    
    with torch.no_grad():
        for inputs, labels in test_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            outputs = model(inputs)
            _, preds = torch.max(outputs, 1)
            
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
    
    return all_labels, all_preds

def generate_confusion_matrix(labels, preds, class_names):
    cm = confusion_matrix(labels, preds)
    plt.figure(figsize=(20, 20))
    sns.heatmap(cm, annot=True, fmt="d", cmap="Blues", 
                xticklabels=class_names, 
                yticklabels=class_names)
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.title("Confusion Matrix")
    plt.savefig("confusion_matrix.png", bbox_inches="tight")
    plt.close()

def generate_classification_report(labels, preds, class_names):
    report = classification_report(
        labels, preds, target_names=class_names, output_dict=True
    )
    return report

def plot_accuracy_curves(history):
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.plot(history['train_acc'], label='Train Accuracy')
    plt.plot(history['val_acc'], label='Validation Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()
    
    plt.subplot(1, 2, 2)
    plt.plot(history['train_loss'], label='Train Loss')
    plt.plot(history['val_loss'], label='Validation Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()
    
    plt.savefig("training_curves.png")
    plt.close()

def main(model_path, test_data_dir):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    # Load model
    model = SignLanguageTransformer(
        input_dim=75*3, 
        num_classes=settings.num_classes
    ).to(device)
    model.load_state_dict(torch.load(model_path))
    model.eval()
    
    # Load test data
    test_dataset = ISLDataset(test_data_dir, mode='test')
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)
    
    # Evaluate
    labels, preds = evaluate_model(model, test_loader, device)
    
    # Generate reports
    class_names = [settings.label_mappings[str(i)]['en'] for i in range(settings.num_classes)]
    generate_confusion_matrix(labels, preds, class_names)
    report = generate_classification_report(labels, preds, class_names)
    
    # Save report
    with open("classification_report.json", "w") as f:
        json.dump(report, f, indent=2)
    
    print(f"Test Accuracy: {report['accuracy']:.4f}")