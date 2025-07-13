import torch
import torch.optim as optim
import torch.nn as nn
from torch.utils.data import DataLoader
from .dataset import ISLDataset
from app.model import SignLanguageModel
from app.utils import load_config
# Load configuration
from app.core.config import settings

config = load_config()

# Hyperparameters
BATCH_SIZE = 32
EPOCHS = 50
LEARNING_RATE = 0.001

def train():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    # Load datasets
    train_dataset = ISLDataset(config['train_data_path'])
    val_dataset = ISLDataset(config['val_data_path'])
    
    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE)
    
    # Initialize model
    model = SignLanguageModel(
        input_size=config['input_size'],
        hidden_size=128,
        num_classes=config['num_classes']
    ).to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)
    
    # Training loop
    for epoch in range(EPOCHS):
        model.train()
        running_loss = 0.0
        
        for inputs, labels in train_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
        
        # Validation
        model.eval()
        val_loss = 0.0
        correct = 0
        total = 0
        
        with torch.no_grad():
            for inputs, labels in val_loader:
                inputs, labels = inputs.to(device), labels.to(device)
                outputs = model(inputs)
                loss = criterion(outputs, labels)
                val_loss += loss.item()
                
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
        
        print(f"Epoch {epoch+1}/{EPOCHS} | "
              f"Train Loss: {running_loss/len(train_loader):.4f} | "
              f"Val Loss: {val_loss/len(val_loader):.4f} | "
              f"Accuracy: {100*correct/total:.2f}%")
    
    # Save model
    torch.save(model.state_dict(), config['model_save_path'])
    
    # Export to TorchScript
    model_scripted = torch.jit.script(model)
    model_scripted.save(config['torchscript_path'])