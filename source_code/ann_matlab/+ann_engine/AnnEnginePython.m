classdef AnnEnginePython < ann_engine.AnnEngineAbstract
    %% properties
    properties (SetAccess = private, GetAccess = private)
        hostname
        port
        timeout
        client_obj
    end
    
    %% init
    methods (Access = public)
        function self = AnnEnginePython(hostname, port, timeout)
            self = self@ann_engine.AnnEngineAbstract();
            self.hostname = hostname;
            self.port = port;
            self.timeout = timeout;
            self.client_obj = mat_py_bridge.MatlabPythonClient(hostname, port, timeout);
        end
                
        function [model, history] = train(self, tag_train, inp, out)
            data_inp.type = 'train';
            data_inp.tag_train = tag_train;
            data_inp.inp = inp;
            data_inp.out = out;
            
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')

            model = data_out.model;
            history = data_out.history;
        end
        
        function clean(self)
            data_inp.type = 'clean';
            
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')
        end
        
        function load(self, name, model, history)
            data_inp.type = 'load';
            data_inp.name = name;
            data_inp.model = model;
            data_inp.history = history;
            
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')
        end
                
        function out = predict(self, name, inp)
            data_inp.type = 'predict';
            data_inp.name = name;
            data_inp.inp = inp;
            
            data_out = self.client_obj.run(data_inp);
            assert(data_out.status==true, 'train error')

            out = data_out.out;
        end
    end
end