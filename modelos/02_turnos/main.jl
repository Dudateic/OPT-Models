# ficheiro: modelos/02_turnos/main.jl

using JuMP
using HiGHS

function resolver_turnos(custos_diarios::Vector{Int}, procura_diaria::Vector{Int}, max_dias_por_pessoa::Int)
    n_funcionarios = length(custos_diarios)
    n_dias = length(procura_diaria)
    
    modelo = Model(HiGHS.Optimizer)
    set_silent(modelo)
    
    # variável de decisão: Se o funcionário i trabalha no dia j, 0 caso contrário
    @variable(modelo, x[1:n_funcionarios, 1:n_dias], Bin)
    
    # diária: para cada dia j, a soma de funcionários a trabalhar tem de ser pelo menos a procura exigida
    for j in 1:n_dias
        @constraint(modelo, sum(x[i, j] for i in 1:n_funcionarios) >= procura_diaria[j])
    end
    
    # dias de trabalho: nenhum funcionário pode exceder o limite de dias trabalhados no período
    for i in 1:n_funcionarios
        @constraint(modelo, sum(x[i, j] for j in 1:n_dias) <= max_dias_por_pessoa)
    end
    
    # função objetivo (minimizar o custo total da folha de pagamento)
    @objective(modelo, Min, sum(custos_diarios[i] * x[i, j] for i in 1:n_funcionarios, j in 1:n_dias))
    
    optimize!(modelo)
    
    if termination_status(modelo) == MOI.OPTIMAL
        custo_total = objective_value(modelo)
        escala = value.(x)
        return custo_total, escala
    else
        println("Não foi possível encontrar uma escala viável")
        return 0.0, zeros(n_funcionarios, n_dias)
    end
end

function ler_ficheiro(caminho::String)
    linhas = readlines(caminho)
    max_dias = parse(Int, linhas[1])
    custos = parse.(Int, split(linhas[2]))
    procura = parse.(Int, split(linhas[3]))
    return max_dias, custos, procura
end

function ler_stdin()
    max_dias = parse(Int, readline())
    custos = parse.(Int, split(readline()))
    procura = parse.(Int, split(readline()))
    return max_dias, custos, procura
end

function main()
    max_dias, custos, procura = 0, Int[], Int[]

    if length(ARGS) > 0
        max_dias, custos, procura = ler_ficheiro(ARGS[1])
    else
        max_dias, custos, procura = ler_stdin()
    end
    
    custo_total, escala = resolver_turnos(custos, procura, max_dias)
    
    println("Status: Otimização concluída.")
    println("Custo total mínimo: ", custo_total)
    println("\nEscala gerada (1 = Trabalha, 0 = Folga):")
    
    for i in 1:length(custos)
        print("Funcionario $i (R\$$(custos[i])/dia): ")
        for j in 1:length(procura)
            print(escala[i, j] > 0.5 ? "[X] " : "[ ] ")
        end
        println()
    end
end

main()