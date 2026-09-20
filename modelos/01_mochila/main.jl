# ficheiro: modelos/01_mochila/main.jl

using JuMP
using HiGHS

"""
Resolve o Problema da Mochila (Knapsack 0-1) maximizando o valor total
sem exceder a capacidade máxima.
"""
function resolver_mochila(pesos::Vector{Int}, valores::Vector{Int}, capacidade::Int)
    n_itens = length(pesos)
    
    # Inicializar o modelo e associar o solver HiGHS
    modelo = Model(HiGHS.Optimizer)
    
    # Desativar os logs matemáticos do solver para manter o output limpo
    set_silent(modelo)
    
    # Variáveis de decisão (1 = leva o item, 0 = não leva)
    @variable(modelo, x[1:n_itens], Bin)
    
    # Restrição de capacidade
    @constraint(modelo, sum(pesos[i] * x[i] for i in 1:n_itens) <= capacidade)
    
    # Função Objetivo (Maximizar o valor acumulado)
    @objective(modelo, Max, sum(valores[i] * x[i] for i in 1:n_itens))
    
    optimize!(modelo)
    
    if termination_status(modelo) == MOI.OPTIMAL
        itens_escolhidos = [i for i in 1:n_itens if value(x[i]) > 0.5]
        lucro_maximo = objective_value(modelo)
        return lucro_maximo, itens_escolhidos
    else
        println("Não foi possível encontrar uma solução ótima.")
        return 0.0, Int[]
    end
end

function ler_ficheiro(caminho::String)
    linhas = readlines(caminho)
    capacidade = parse(Int, linhas[1])
    pesos = parse.(Int, split(linhas[2]))
    valores = parse.(Int, split(linhas[3]))
    return capacidade, pesos, valores
end

function ler_stdin()
    capacidade = parse(Int, readline())
    pesos = parse.(Int, split(readline()))
    valores = parse.(Int, split(readline()))
    
    return capacidade, pesos, valores
end

function main()
    capacidade, pesos, valores = 0, Int[], Int[]

    if length(ARGS) > 0
        caminho_ficheiro = ARGS[1]
        capacidade, pesos, valores = ler_ficheiro(caminho_ficheiro)
        println("Ficheiro: $caminho_ficheiro)")
    else
        capacidade, pesos, valores = ler_stdin()
    end
    
    println("Capacidade limite: ", capacidade)
    println("Pesos dos itens:   ", pesos)
    println("Valores dos itens: ", valores)
    
    lucro, itens = resolver_mochila(pesos, valores, capacidade)
    
    println("Status: Concluído com sucesso.")
    println("Lucro máximo alcançado: ", lucro)
    println("Itens selecionados (índices): ", itens)
end

main()