import torch
import torch.nn as nn
import torch.nn.functional as F

class SPARK_Net(nn.Module):
    def __init__(self,coils,kernelsize,acs):
        super().__init__()
        self.acs = acs

        self.conv1 = nn.Conv2d(coils*2, coils*2, kernelsize, padding=1, bias=False)
        self.conv2 = nn.Conv2d(coils*2, coils, 1, padding=0, bias=False)
        self.conv3 = nn.Conv2d(coils, coils*2, kernelsize, padding=1, bias=False)
        self.conv4 = nn.Conv2d(coils*2, coils, kernelsize, padding=1, bias=False)
        self.conv5 = nn.Conv2d(coils, coils//4, 1, padding=0, bias=False)
        self.conv6 = nn.Conv2d(coils//4, 1, kernelsize, padding=1, bias=False)

    def forward(self, x):
        y = F.relu(self.conv1(x))
        y = F.relu(self.conv2(y))
        y = F.relu(self.conv3(y))
        z = x + y
        z = F.relu(self.conv4(z))
        z = F.relu(self.conv5(z))
        out = self.conv6(z)

        loss_out = out[:,:,:,self.acs]

        return out, loss_out

class SPARK_Netv2(nn.Module):
    def __init__(self,coils,kernelsize,acsx,acsy,naliniflag = 0):
        super().__init__()
        self.acsx = acsx
        self.acsy = acsy
        self.naliniflag = naliniflag
        
        self.conv1 = nn.Conv2d(coils*2, coils*2, kernelsize, padding=1, bias=False)
        self.conv2 = nn.Conv2d(coils*2, coils, 1, padding=0, bias=False)
        self.conv3 = nn.Conv2d(coils, coils*2, kernelsize, padding=1, bias=False)
        self.conv4 = nn.Conv2d(coils*2, coils, kernelsize, padding=1, bias=False)
        self.conv5 = nn.Conv2d(coils, coils//4, 1, padding=0, bias=False)
        self.conv6 = nn.Conv2d(coils//4, 1, kernelsize, padding=1, bias=False)
        
    def naliniRelu(self,inp):
        #An attempt at implementing Nalini's custom nonlinearity, from "Joint Frequency- and Image-Space Learning for Fourier Imaging"
        return inp + F.relu((inp-1)/2) + F.relu((-inp-1)/2)       

    def forward(self, x):
        
        if(self.naliniflag):
            y = self.naliniRelu(self.conv1(x))
            y = self.naliniRelu(self.conv2(y))
            y = self.naliniRelu(self.conv3(y))
            z = x + y
            z = self.naliniRelu(self.conv4(z))
            z = self.naliniRelu(self.conv5(z))
            out = self.conv6(z)
        else:
            y = F.relu(self.conv1(x))
            y = F.relu(self.conv2(y))
            y = F.relu(self.conv3(y))
            z = x + y
            z = F.relu(self.conv4(z))
            z = F.relu(self.conv5(z))
            out = self.conv6(z)
        
        loss_out = out[:,:,self.acsx[0]:self.acsx[-1]+1,self.acsy[0]:self.acsy[-1]+1]

        return out, loss_out


class SPARK_Netv3(nn.Module):
    def __init__(self,coils,kernelsize,trainingMask):
        super().__init__()
        self.trainingMask = trainingMask

        self.conv1 = nn.Conv2d(coils*2, coils*2, kernelsize, padding=1, bias=False)
        self.conv2 = nn.Conv2d(coils*2, coils, 1, padding=0, bias=False)
        self.conv3 = nn.Conv2d(coils, coils*2, kernelsize, padding=1, bias=False)
        self.conv4 = nn.Conv2d(coils*2, coils, kernelsize, padding=1, bias=False)
        self.conv5 = nn.Conv2d(coils, coils//4, 1, padding=0, bias=False)
        self.conv6 = nn.Conv2d(coils//4, 1, kernelsize, padding=1, bias=False)

    def forward(self, x):
        y = F.relu(self.conv1(x))
        y = F.relu(self.conv2(y))
        y = F.relu(self.conv3(y))
        z = x + y
        z = F.relu(self.conv4(z))
        z = F.relu(self.conv5(z))
        out = self.conv6(z)

        loss_out = out * self.trainingMask

        return out, loss_out

class autoencoder_4(nn.Module):
    def __init__(self,input_dimension,hidden_dimension):
        super().__init__()

        self.input_fc_1  = nn.Linear(input_dimension,input_dimension//2)
        self.input_fc_2  = nn.Linear(input_dimension//2,input_dimension//4)
        self.input_fc_3  = nn.Linear(input_dimension//4,input_dimension//8)
        self.input_fc_4  = nn.Linear(input_dimension//8,hidden_dimension)
        self.output_fc_1 = nn.Linear(hidden_dimension,input_dimension//8)
        self.output_fc_2 = nn.Linear(input_dimension//8,input_dimension//4)
        self.output_fc_3 = nn.Linear(input_dimension//4,input_dimension//2)
        self.output_fc_4 = nn.Linear(input_dimension//2,input_dimension)

    def encode(self,x):
        return F.leaky_relu(self.input_fc_4(F.leaky_relu(self.input_fc_3(F.leaky_relu(self.input_fc_2(F.leaky_relu(self.input_fc_1(x))))))))

    def decode(self,x):
        return self.output_fc_4(F.leaky_relu(self.output_fc_3(F.leaky_relu(self.output_fc_2(F.leaky_relu(self.output_fc_1(x)))))))

    def forward(self,x):
        out = F.leaky_relu(self.input_fc_1(x))
        out = F.leaky_relu(self.input_fc_2(out))
        out = F.leaky_relu(self.input_fc_3(out))
        out = F.leaky_relu(self.input_fc_4(out))
        out = F.leaky_relu(self.output_fc_1(out))
        out = F.leaky_relu(self.output_fc_2(out))
        out = F.leaky_relu(self.output_fc_3(out))
        out = self.output_fc_4(out)
        return out
    
class autoencoder_3(nn.Module):
    def __init__(self,input_dimension,hidden_dimension):
        super().__init__()

        self.input_fc_1  = nn.Linear(input_dimension,input_dimension//2)
        self.input_fc_2  = nn.Linear(input_dimension//2,input_dimension//4)
        self.input_fc_3  = nn.Linear(input_dimension//4,hidden_dimension)
        self.output_fc_1 = nn.Linear(hidden_dimension,input_dimension//4)
        self.output_fc_2 = nn.Linear(input_dimension//4,input_dimension//2)
        self.output_fc_3 = nn.Linear(input_dimension//2,input_dimension)

    def encode(self,x):
        return F.leaky_relu(self.input_fc_3(F.leaky_relu(self.input_fc_2(F.leaky_relu(self.input_fc_1(x))))))

    def decode(self,x):
        return self.output_fc_3(F.leaky_relu(self.output_fc_2(F.leaky_relu(self.output_fc_1(x)))))

    def forward(self,x):
        out = F.leaky_relu(self.input_fc_1(x))
        out = F.leaky_relu(self.input_fc_2(out))
        out = F.leaky_relu(self.input_fc_3(out))
        out = F.leaky_relu(self.output_fc_1(out))
        out = F.leaky_relu(self.output_fc_2(out))
        out = self.output_fc_3(out)
        return out
    
class autoencoder_1(nn.Module):
    def __init__(self,input_dimension,hidden_dimension):
        super().__init__()

        self.input_fc  = nn.Linear(input_dimension,hidden_dimension)
        self.output_fc = nn.Linear(hidden_dimension,input_dimension)

    def encode(self,x):
        return F.leaky_relu(self.input_fx(x))

    def decode(self,x):
        return self.output_fc(x)

    def forward(self,x):
        out = self.output_fc(F.leaky_relu(self.input_fc(x)))
        return out

class autoencoder_2(nn.Module):
    def __init__(self,input_dimension,hidden_dimension):
        super().__init__()

        self.input_fc_1  = nn.Linear(input_dimension,input_dimension//2)
        self.input_fc_2  = nn.Linear(input_dimension//2,hidden_dimension)
        self.output_fc_1 = nn.Linear(hidden_dimension,input_dimension//2)
        self.output_fc_2 = nn.Linear(input_dimension//2,input_dimension)

    def encode(self,x):
        return F.leaky_relu(self.input_fc_2(F.leaky_relu(self.input_fc_1(x))))

    def decode(self,x):
        return self.output_fc_2(F.leaky_relu(self.output_fc_1(x)))

    def forward(self,x):
        out = F.leaky_relu(self.input_fc_1(x))
        out = F.leaky_relu(self.input_fc_2(out))
        out = F.leaky_relu(self.output_fc_1(out))
        out = self.output_fc_2(out)
        return out
    
class autoencoder(nn.Module):
    def __init__(self,input_dimension,hidden_dimension,model_layers = 2, nonlinearity = 'leakyrelu'):
        super().__init__()
        
        if(nonlinearity == 'leakyrelu'):
            self.activation = F.leaky_relu
        elif(nonlinearity == 'relu'):
            self.activation = F.relu
        elif(nonlinearity == 'tanh'):
            self.activation = torch.tanh
        elif(nonlinearity == 'nalini'):
            self.activation = self.nalini
        elif(nonlinearity == 'htanh'):
            self.activation = F.hardtanh
        elif(nonlinearity == 'selu'):
            self.activation = torch.nn.SELU()
            
        self.encoding_layers = nn.ModuleList([])
        for ii in range(model_layers):
            if(ii < (model_layers - 1)):#last layer goes from current dimension directly to latent dimension
                self.encoding_layers.append(nn.Linear(input_dimension // 2**ii, input_dimension // 2**(ii+1)))              
            else:
                self.encoding_layers.append(nn.Linear(input_dimension // 2**ii, hidden_dimension))
                
        
        self.decoding_layers = nn.ModuleList([])
        self.decoding_layers.append(nn.Linear(hidden_dimension,input_dimension//2**(model_layers-1)))
        for ii in range(model_layers-1):
            self.decoding_layers.append(nn.Linear(input_dimension//2**(model_layers-(ii+1)),\
                                       input_dimension//2**(model_layers-(ii+1)-1)))

    def nalini(self,x):
        return x + F.relu((x-1)/2) + F.relu((-x-1)/2)
        
    def decode(self,x):
        out = x
        out = self.decoding_layers[0](out)
        for ii in range(len(self.decoding_layers)-1):
            out = self.activation(out)
            out = self.decoding_layers[ii+1](out)
            
        return out
    
    def encode(self,x):
        out = x
        for layer in self.encoding_layers:
            out = layer(out)
            out = self.activation(out)
        return out

    def forward(self,x):
        return self.decode(self.encode(x))