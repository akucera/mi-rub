# graph
class Graph
  attr_accessor :id;
  def initialize(id, vertices = {})
    @id = id;
    @vertices = vertices;
  end

  def add_vertex(vertex)
    @vertices[vertex.id] = vertex;
  end

  def get_vertex(vertexId)
    @vertices[vertexId];
  end

end

# graph vertex
class Vertex
  attr_accessor :id;
  attr_reader :adjv;
  def initialize(id, adjv = [])
    @id = id;
    @adjv = adjv;
  end

  def add_adjv(vertex)
    @adjv.push(vertex);
  end

  def to_s()
    @id;
  end
end

# configuration for traverser
class TraversingConfiguration
  attr_accessor :type, :vertex_id;
  def initialize(type, vertex_id)
    @type = type;
    @vertex_id = vertex_id;
  end
end

# graph traverser
class Traverser
  def initialize(graph, configurations)
    @graph = graph;
    @vertex = nil;
    @stack = [];
    @visited = [];
    @configurations = configurations;
    @type = nil;
  end

  def execute
    puts "graph #{@graph.id}";
    #puts "executing with configurations #{@configurations}"
    @configurations.each {
      |config|
      #puts "config run"
      @visited.clear();
      @stack.clear();
      #puts "Getting vertex #{config.vertex_id}"
      @vertex = @graph.get_vertex(config.vertex_id);
      @type = config.type;
      #expand first vertex
      expand_vertex(@vertex)
      #expand all remaining vertices
      while (!@stack.empty?)
        @type == :BFS ? expand_vertex(@stack.shift()) : expand_vertex(@stack.pop());
      end
      #print output
      #TODO shit, cleanup!!!
      @output = "";
      @visited.each() {
        |vtx|
        @output += "#{vtx.id} ";
      }
      puts @output.strip;
    }
  end

  private
  def expand_vertex(vertex)
    @visited.push(vertex);
    @type == :BFS ? @arr = vertex.adjv : @arr = vertex.adjv.reverse;
    @arr.each  { 
      |vtx|
      #insert vertex if it is not already visited
      if (!@visited.include?(vtx))
      #is current vertex on stack?
        if (@type == :DFS && @stack.include?(vtx))
        #if yes, we probable found better way (only with DFS)
          @stack.delete(vtx);
          @stack.push(vtx)
        elsif (!@stack.include?(vtx))
          @stack.push(vtx)
        end
      end
    }
  end
end

# builds graphs (from file), configures traversers and execute them
class Executor
  def initialize(config_name)
    @config_name = config_name;
  end
  
  def run
    @traversers = [];
    f = File.open(@config_name, "r");
    @graph_count = Integer(f.gets.chomp);
    @graph_count.times {
      |g|
      @configurations = [];
      @graph = Graph.new(g + 1);
      @vertex_count = Integer(f.gets.chomp);
      @vertex_count.times {
        @line = f.gets.chomp.split(/ /);
        @vertex = @graph.get_vertex(@line[0])
        if (@vertex == nil)
          @vertex = Vertex.new(@line[0]);
          @graph.add_vertex(@vertex);
        end
        if (!((@line.length == 2) && (@line[1] == "0")))
          @line.shift
          @line.each {
            |item|
            @adjv = nil;
            @adjv = @graph.get_vertex(item)
            if (@adjv == nil)
              @adjv = Vertex.new(item);
              @graph.add_vertex(@adjv);
            end
            @vertex.add_adjv(@adjv);
          }
        end
      }
      while (@line = f.gets)
        @line = @line.chomp.split(/ /);
        if ((@line.length == 2) && (@line[0] == "0") && (@line[1] == "0"))
          break;
        end
        if (@line[1] == "0") 
          @type = :DFS;
        elsif (@line[1] == "1")
          @type = :BFS;
        else
        #recovery scenario if type is not set
          @type = :BFS;
        end 
        @configuration = TraversingConfiguration.new(@type,@line[0]);
        @configurations.push(@configuration);
      end
      @traverser = Traverser.new(@graph,@configurations);
      @traversers.push(@traverser);
    }
    
    @traversers.each {
      |traverser|
      traverser.execute();
    }
  end
  
end

executor = Executor.new("vzor")
executor.run()
