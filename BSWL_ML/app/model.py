import torch
import torch.nn as nn

class SignLanguageModel(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes, num_layers=2):
        super(SignLanguageModel, self).__init__()
        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            bidirectional=True
        )
        self.fc = nn.Linear(hidden_size * 2, num_classes)  # Bidirectional
        self.dropout = nn.Dropout(0.3)
        self.softmax = nn.Softmax(dim=1)

    def forward(self, x):
        out, _ = self.lstm(x)
        out = out[:, -1, :]  # Last timestep
        out = self.dropout(out)
        out = self.fc(out)
        return self.softmax(out)

def load_model(model_path, device='cpu'):
    model = torch.jit.load(model_path, map_location=device)
    model.eval()
    return model